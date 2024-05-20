# Parameters

```text
target_application=jay-proj
application_to_modify=add_one_proj
action=add
project=default
optional_id=${5:-}
```

# Add one deny sync window

```shell
chmod +x update_argocd_window.sh
./update_argocd_window.sh jay-proj add_one add default
```

# Delete one deny sync window

```shell
chmod +x update_argocd_window.sh
./update_argocd_window.sh jay-proj add_one delete default
```

# Id Mismatch Test

```shell
chmod +x update_argocd_window.sh
./update_argocd_window.sh jay-proj add_one delete default 1234
```

# Project Mismatch Test

```shell
chmod +x update_argocd_window.sh
./update_argocd_window.sh jay-pro222j add_one delete default
```