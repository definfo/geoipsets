{
  description = "Mirror clone @ SJTUG";

  inputs = {
    nixpkgs.url = "git+https://mirrors.tuna.tsinghua.edu.cn/git/nixpkgs.git?ref=nixpkgs-unstable&shallow=1";
  };

  outputs = { self, nixpkgs }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
    in
  {
    packages.${system} = {
      geoipsets = pkgs.callPackage ./package.nix {
         version = self.rev or "dirty"; 
      };
      default = self.packages.${system}.geoipsets;
    };
      
    devShells.${system}.default = pkgs.mkShell {
      strictDeps = true;
      nativeBuildInputs = with pkgs; [
        python3
        uv
        ruff
        basedpyright
      ];
    };
  };
}
