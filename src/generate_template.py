import pathlib
import os
import jinja2
import dotenv

if pathlib.Path(".env.example").exists():
    dotenv.load_dotenv(".env.example")


def load_template_from_path(path: str):
    path, file_name = os.path.split(path)
    return jinja2.Environment(
        loader=jinja2.FileSystemLoader(path or "./")
    ).get_template(file_name)


def build_deployment_manifest_from_path(path: str):
    template = load_template_from_path(path)
    content = template.render(os.environ)

    with open("/tmp/deployment.tmp.json", mode="w", encoding="utf-8") as f:
        f.write(content)


if __name__ == "__main__":
    build_deployment_manifest_from_path(
        "./templates/deployment.edge.dev.inference_v0.json"
    )
