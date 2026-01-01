# How to Create a Release

This document explains how to create a new release of Flüstern with automatic builds for all platforms.

## Prerequisites

- Push access to the GitHub repository
- All changes committed and pushed to main branch
- Tests passing (if applicable)

## Release Process

### 1. Update Version

Update the version in `pubspec.yaml`:

```yaml
version: 1.2.0+3  # Format: MAJOR.MINOR.PATCH+BUILD_NUMBER
```

Commit the version change:

```bash
git add pubspec.yaml
git commit -m "Bump version to 1.2.0"
git push origin main
```

### 2. Create and Push a Tag

Create a version tag (must start with `v`):

```bash
# Format: v<MAJOR>.<MINOR>.<PATCH>
git tag v1.2.0

# Push the tag to GitHub
git push origin v1.2.0
```

### 3. Automatic Build & Release

Once the tag is pushed, GitHub Actions will automatically:

1. **Create a GitHub Release** with the version number
2. **Build for all platforms**:
   - Windows (.zip with .exe)
   - macOS (.zip with .app)
   - Linux (.tar.gz)
3. **Upload all builds** to the GitHub Release
4. **Publish the release** (not a draft)

You can monitor the build progress at:
```
https://github.com/chuk-development/fluistern/actions
```

### 4. Edit Release Notes (Optional)

After the automatic release is created, you can edit it to add:
- Changelog
- New features
- Bug fixes
- Breaking changes

Go to: `https://github.com/chuk-development/fluistern/releases`

## Versioning Guidelines

Follow [Semantic Versioning](https://semver.org/):

- **MAJOR** version: Incompatible API changes
- **MINOR** version: New functionality (backwards-compatible)
- **PATCH** version: Bug fixes (backwards-compatible)

### Examples

- `v1.0.0` - Initial release
- `v1.1.0` - Added command mode feature
- `v1.1.1` - Fixed bug in transcription
- `v2.0.0` - Complete UI redesign (breaking changes)

## Manual Build (If Needed)

If you need to build manually for testing:

### Windows
```bash
flutter build windows --release
cd build/windows/x64/runner/Release
# Package all files into a zip
```

### macOS
```bash
flutter build macos --release
cd build/macos/Build/Products/Release
zip -r fluistern-macos.zip fluistern_app.app
```

### Linux
```bash
flutter build linux --release
cd build/linux/x64/release/bundle
tar -czf fluistern-linux.tar.gz *
```

## Troubleshooting

### Build Fails

Check the GitHub Actions logs:
1. Go to repository → Actions tab
2. Click on the failed workflow
3. Check which job failed (Windows/macOS/Linux)
4. Read the error logs

Common issues:
- **Missing dependencies**: Update workflow file with required packages
- **Flutter version**: Ensure workflow uses correct Flutter version
- **Platform-specific errors**: May need platform-specific fixes

### Tag Already Exists

If you need to recreate a tag:

```bash
# Delete local tag
git tag -d v1.2.0

# Delete remote tag
git push origin :refs/tags/v1.2.0

# Create new tag
git tag v1.2.0
git push origin v1.2.0
```

### Release Not Created

Ensure:
- Tag format is correct (starts with `v`)
- GitHub Actions has permissions to create releases
- No other release with same tag exists

## Testing Before Release

Before creating a release tag:

1. **Test on all platforms locally**:
   ```bash
   flutter test
   flutter build windows --release  # On Windows
   flutter build macos --release    # On macOS
   flutter build linux --release    # On Linux
   ```

2. **Run the built app** to ensure it works

3. **Check for errors** in the console

## After Release

1. **Test downloads**: Download each platform build and test
2. **Update README**: If necessary, update documentation
3. **Announce**: Share the release (if applicable)
4. **Monitor issues**: Check for bug reports from users

---

**Quick Reference**:
```bash
# Full release process
git add .
git commit -m "Bump version to X.Y.Z"
git push origin main
git tag vX.Y.Z
git push origin vX.Y.Z
# Wait for GitHub Actions to complete
```
