{
    "maintainer": "Yash Ratawa",
    "package_name": "postgresql",
    "github_url": "https://github.com/postgres/postgres",
    "version": "17.5",
    "default_branch": "master",
    "package_dir": "p/postgresql",
    "build_script": "postgresql_ubi_9_3.sh",
    "docker_build": false,
    "validate_build_script": true,
    "use_non_root_user": false,
     "*": {
         "dir": "17.5_ubi9.3",
         "build_script": "postgresql_ubi_9_3.sh"
     }
}
