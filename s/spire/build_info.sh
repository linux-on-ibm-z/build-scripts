{
    "maintainer": "Sonal Deshmukh",
    "package_name": "spire",
    "github_url": "https://github.com/spiffe/spire.git",
    "version": "1.12.4",
    "default_branch": "master",
    "package_dir": "s/spire",
    "build_script": "spire_ubi_9_3.sh",
    "docker_build": false,
    "validate_build_script": true,
    "use_non_root_user": false,
     "*": {
         "dir": "1.12.4_ubi9.3",
         "build_script": "spire_ubi_9_3.sh"
     }
}
