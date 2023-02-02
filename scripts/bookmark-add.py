#!/usr/bin/env python

import argparse
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from html.parser import HTMLParser


def git_is_dirty(path: Path) -> bool:
    p = subprocess.run(["git", "-C", str(path), "diff", "--quiet"])
    return p.returncode != 0


def git_commit(path: Path, file: Path, msg: str) -> None:
    subprocess.run(["git", "-C", str(path), "commit", "-m", msg, str(file)], check=True)


def git_push(path: Path) -> None:
    subprocess.run(["git", "-C", str(path), "push"], check=True)


def git_root(path: Path) -> Path:
    p = subprocess.run(["git", "-C", str(path), "rev-parse", "--show-toplevel"], capture_output=True, check=True)
    return Path(p.stdout.decode().strip())


class TitleParser(HTMLParser):
    def __init__(self):
        HTMLParser.__init__(self)
        self.match = False
        self.title = ''

    def handle_starttag(self, tag, attributes):
        self.match = tag == 'title'

    def handle_data(self, data):
        if self.match:
            self.title = data
            self.match = False


def fetch_url(url: str) -> str:
    p = subprocess.run(["curl", "-Ls", url], check=True, capture_output=True)
    return p.stdout.decode()


def add_line(path: Path, line: str) -> None:
    subprocess.run(["sed", "-i", "--follow-symlinks", f"7 i {line}", str(path)], check=True, capture_output=True)
    

def extract_title(raw: str) -> str:
    parser = TitleParser()
    parser.feed(raw)
    return parser.title


def generate_markdown_line(url: str) -> str:
    raw = fetch_url(url)
    title = extract_title(raw)
    today = datetime.today()
    return f"* {today.strftime('%Y-%m-%d')}: [{title}]({url})"


def process_url(url: str, bookmarks: Path, dry: bool) -> None:
    line = generate_markdown_line(url)
    print(line)
    if not dry:
        add_line(bookmarks, line)
    

def parse_args() -> argparse.Namespace:
    default_file = Path.home() / "Projects" / "private" / "blog" / "content" / "bookmarks.md"
    
    parser = argparse.ArgumentParser()
    parser.add_argument("-p", "--path", type=Path, default=default_file, help="path to bookmarksfile")
    parser.add_argument("-d", "--dry-run", action="store_true", help="just print the lines")
    parser.add_argument("-c", "--commit", action="store_true", help="commit the changes")
    parser.add_argument("-P", "--push", action="store_true", help="push after successful commit; implies -c")
    parser.add_argument("URL", nargs="+", help="url to add to my bookmarks")
    return parser.parse_args()


def main():
    args = parse_args()
    urls = []
    repopath = git_root(args.path.parent)
    
    if args.commit and git_is_dirty(repopath):
        print(f"repo at '{repopath}' is dirty", file=sys.stderr)
        sys.exit(1)

    print(f"adding to {args.path}")
    for url in args.URL:
        if url == "-":
            for line in sys.stdin.read().splitlines():
                urls.append(line)
                process_url(line, args.path, args.dry_run)
        else:
            urls.append(url)
            process_url(url, args.path, args.dry_run)

    if args.commit or args.push:
        msg = f"added {len(urls)} bookmarks\n\n"
        for url in urls:
            msg += f"* {url}\n"

        git_commit(repopath, args.path, msg.strip())

        if args.push:
            git_push(repopath)
        


if __name__ == '__main__':
    main()
