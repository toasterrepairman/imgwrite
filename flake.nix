{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils, ... }@inputs:
    utils.lib.eachDefaultSystem
      (system:
        let
          name = "imgwrite";
          
	      system = "x86_64-linux";
	      pkgs = import nixpkgs {
	        inherit system;
	        config.allowUnfree = true;
	        config.cudaSupport = true;
	      };
        in 
        rec {
          packages.${name} = pkgs.callPackage ./default.nix {
            inherit (inputs);
          };

          # `nix build`
          defaultPackage = packages.${name};

          # `nix run`
          apps.${name} = utils.lib.mkApp {
            inherit name;
            drv = packages.${name};
          };
          defaultApp = packages.${name};

          # `nix develop`
          devShells = {
            default = pkgs.mkShell {
              propagatedBuildInputs = [ pkgs.cudatoolkit ];
            
              nativeBuildInputs =
                with pkgs; [
                  rustc
                  cargo
                  cairo
                  openssl
                  pkg-config
                  git
                  cudatoolkit linuxPackages.nvidia_x11
                  cudaPackages.cudnn
                  libGLU libGL
                  xorg.libXi xorg.libXmu freeglut
                  xorg.libXext xorg.libX11 xorg.libXv xorg.libXrandr zlib 
                  ncurses5 stdenv.cc binutils
                  ffmpeg
                ];
		                
		        shellHook = ''
		            export LD_LIBRARY_PATH="${pkgs.linuxPackages.nvidia_x11}/lib"
		        '';  
		        CUDA_ROOT = pkgs.cudatoolkit;        
            };
          };
        }
      );
}
