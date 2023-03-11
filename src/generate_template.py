import sys
import getopt
import os
import json
import yaml


def build_module_dict(module_settings):
    module = dict()

    module["type"] = "docker"
    module["status"] = "running"
    module["restartPolicy"] = "always"
    module["settings"] = dict()

    environment = {}
    for environment_variable in module_settings["environment"]:
        (
            environment_variable_name,
            environment_variable_value,
        ) = environment_variable.split("=")

        environment[environment_variable_name] = {"value": environment_variable_value}

    module["env"] = environment
    module["settings"]["image"] = module_settings["settings"]["image"]

    if "createOptions" in module_settings["settings"]:
        module["settings"]["createOptions"] = module_settings["settings"][
            "createOptions"
        ]

    return module


def build_container_registry_dict(container_registry_settings):
    container_registry = dict()

    container_registry["address"] = container_registry_settings["address"]
    container_registry["username"] = container_registry_settings["username"]
    container_registry["password"] = container_registry_settings["password"]

    return container_registry


def load_template_from_path(path: str):
    with open(path, mode="r", encoding="utf-8") as f:
        return json.loads(f.read())


def load_configuration_from_path(path: str):
    with open(path, mode="r", encoding="utf-8") as f:
        return yaml.safe_load(f.read())


def parse_configuration(configuration):
    return dict(
        target_condition=configuration["target_condition"],
        container_registries=configuration["container_registries"],
        modules=configuration["modules"],
    )


def build_deployment_manifest_from_dict(deployment_manifest_dict):
    with open("./tmp/deployment.tmp.json", mode="w", encoding="utf-8") as f:
        f.write(deployment_manifest_dict)


if __name__ == "__main__":
    argv = sys.argv[1:]
    options, args = getopt.getopt(
        sys.argv[1:], "c:t", ["configuration-file=", "template-file="]
    )

    for opt, arg in options:
        if opt in ("-c", "--configuration-file"):
            configuration_file_path = arg
        elif opt in ("-t", "--template-file"):
            template_file_path = arg

    loaded_template = load_template_from_path(template_file_path)
    loaded_configuration = load_configuration_from_path(configuration_file_path)

    loaded_configuration = {**loaded_configuration, **os.environ}

    modules = {}
    for module_name, module_settings in loaded_configuration["modules"].items():
        modules[module_name] = build_module_dict(module_settings)

    container_registries = {}
    for container_registry_name, container_registry_settings in loaded_configuration[
        "container_registries"
    ].items():
        container_registries[container_registry_name] = build_container_registry_dict(
            container_registry_settings
        )

    loaded_template["content"]["modulesContent"]["$edgeAgent"]["properties.desired"][
        "runtime"
    ]["settings"]["registryCredentials"] = container_registries

    loaded_template["content"]["modulesContent"]["$edgeAgent"]["properties.desired"][
        "modules"
    ] = modules

    build_deployment_manifest_from_dict(json.dumps(loaded_template))
