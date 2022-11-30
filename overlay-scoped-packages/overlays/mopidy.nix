ifinal: prev:

{
  /* Pay close attention to what's happening with mopidy in pkgs/top-level/all-packages.nix, as going
   * directly after overlaying on mopidy leads to a world of confusing pain.  Namely the "mopidy-with-extensions"
   * is being built with the patched mopidy, but the patched version doesn't really get used because it is pulled
   * in as a library dependency to mopidy-mpd, and ends up with the non-patched version in site-packages. */
  /* The mopidy packages are all declared in a custom scope to ensure consistency, as such the scope must be
   * overriden to update the scope dependencies.  So we start by overriding the scope.  overrideScope' expects a
   * function with two arguments, like the overlay, and not like the attrs overrides. */
  /* With scope, pay close attention to the name, the "'" in overrideScope' is not a typo. */
  mopidyPackages = prev.mopidyPackages.overrideScope' (mopidyFinal: mopidyPrev: {
    # Inside the scope override, override the mopidy package.
    mopidy = mopidyPrev.mopidy.overrideAttrs (oldAttrs:
      let
        # Patch has already been merged for the release that follows 3.3.0, so check
        # the version to allow this overlay to be gracefully removed without a hard
        # break as soon as the next release is made.
        withDbusPatch = (lib.versionOlder oldAttrs.version "3.3.1");
      in
      {
        patches = (oldAttrs.patches or [ ])
          ++ lib.optionals withDbusPatch [ ./mopidy-dbus-exception.patch ];
      });
  });
}
