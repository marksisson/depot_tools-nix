{
  imports = [
    ./depot_tools
  ];

  perSystem = { self', ... }: {
    packages.default = self'.packages.depot_tools;
  };
}
