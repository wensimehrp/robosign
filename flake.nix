{
  description = "Web development environment with Bun";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
  };

  outputs = inputs: {
    devShells = builtins.mapAttrs (system: pkgs: {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
          typst
        ];
      };
    }) inputs.nixpkgs.legacyPackages;
  };
}
