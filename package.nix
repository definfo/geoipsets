{
  lib,
  python3Packages,
  version ? null,
}:

python3Packages.buildPythonApplication {
  pname = "geoipsets";
  inherit version;
  pyproject = true;

  # src = ./python;
  src = lib.fileset.toSource {
    root = ./python;
    fileset = lib.fileset.intersection (lib.fileset.fromSource (lib.sources.cleanSource ./python)) (
      lib.fileset.unions [
        ./python/geoipsets
        ./python/tests
        ./python/geoipsets.conf
        ./python/MANIFEST.in
        ./python/README.md
        ./python/setup.py
      ]
    );
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    requests
    beautifulsoup4
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = {
    description = "Python package to generate country-specific IP network ranges consumable by both iptables/ipset and nftables";
    homepage = "https://github.com/definfo/geoipsets";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ definfo ];
    mainProgram = "geoipsets";
    platforms = lib.platforms.all;
  };
}
