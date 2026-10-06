# Local patches

## go-unifi: `dev_id_override` returned as a string (UniFi Network 11)

UniFi Network 11.0.81 returns a client's `dev_id_override` as a numeric string (for example `"1908"`).
go-unifi v1.9.3 decodes it into an `int`, so reading any client that has a device-type override
fails:

```
unable to unmarshal alias: json: cannot unmarshal string into Go struct field .Alias.dev_id_override of type int
```

`patches/go-unifi-dev-id-override.patch` decodes the field with `emptyStringInt`, as `last_seen`
already is. It applies to go-unifi v1.9.3, the version in `go.mod`.

Build and use:

```
scripts/build-patched.sh                 # writes .patched-build/terraform-provider-unifi
```

OpenTofu CLI config (`TF_CLI_CONFIG_FILE=...`) pointing at the directory holding the binary:

```
provider_installation {
  dev_overrides {
    "filipowm/unifi" = "/path/to/dir"
  }
  direct {}
}
```

Drop the patch when go-unifi releases a fix.
