{ lib, fetchFromGitHub, rustPlatform, pkgconfig, cmake }:

rustPlatform.buildRustPackage rec {
  pname = "firefox-profile-switcher-connector";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "null-dev";
    repo = "firefox-profile-switcher-connector";
    rev = "46dae2a1ed6496814082051aa4347ba2019befe7";
    sha256 = "sha256-mnPpIJ+EQAjfjhrSSNTrvCqGbW0VMy8GHbLj39rR8r4=";
  };

  cargoSha256 = "EQIBeZwF9peiwpgZNfMmjvLv8NyhvVGUjVXgkf12Wig=";

  nativeBuildInputs = [ pkgconfig cmake ];

  meta = with lib; {
    description = "The native component of the Profile Switcher for Firefox extension. Written in Rust.";
    homepage = "https://github.com/null-dev/firefox-profile-switcher-connector";
    license = licenses.gpl3;
    maintainers = [ "rakanalh" ];
  };
}
