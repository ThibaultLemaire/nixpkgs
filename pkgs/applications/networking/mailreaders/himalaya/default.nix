{ lib
, rustPlatform
, fetchFromGitHub
, stdenv
, enableCompletions ? stdenv.hostPlatform == stdenv.buildPlatform
, installShellFiles
, pkg-config
, Security
, libiconv
, openssl
}:

rustPlatform.buildRustPackage rec {
  pname = "himalaya";
  version = "0.5.9";

  src = fetchFromGitHub {
    owner = "soywod";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-g+ySsHnJ4FpmJLEjlutuiJmMkKI3Jb+HkWi1WBIo1aw=";
  };

  cargoSha256 = "sha256-NkkONl57zSilElVAOXUBxWnims4+EIVkkTdExbeBAaQ=";

  nativeBuildInputs = lib.optionals enableCompletions [ installShellFiles ]
    ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [ pkg-config ];

  buildInputs =
    if stdenv.hostPlatform.isDarwin then [
      Security
      libiconv
    ] else [
      openssl
    ];

  # flag added because without end-to-end testing is ran which requires
  # additional tooling and servers to test
  cargoTestFlags = [ "--lib" ];

  postInstall = lib.optionalString enableCompletions ''
    # Install shell function
    installShellCompletion --cmd himalaya \
      --bash <($out/bin/himalaya completion bash) \
      --fish <($out/bin/himalaya completion fish) \
      --zsh <($out/bin/himalaya completion zsh)
  '';

  meta = with lib; {
    description = "Command-line interface for email management";
    homepage = "https://github.com/soywod/himalaya";
    changelog = "https://github.com/soywod/himalaya/blob/v${version}/CHANGELOG.md";
    license = licenses.bsdOriginal;
    maintainers = with maintainers; [ toastal yanganto ];
  };
}
