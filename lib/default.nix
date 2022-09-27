{ system
, pkgs
}:

{	
	host = import ./host.nix {inherit system pgks;};
}
