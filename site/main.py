import os

from flask import Flask, render_template

app = Flask(__name__)


@app.route("/", methods=["GET"])
def index():
    template_name = "main.html"
    template_path = os.path.join(
        app.root_path, app.template_folder or "templates", template_name
    )
    if not os.path.exists(template_path):
        return "Template not found", 404
    try:
        return render_template(template_name)
    except Exception as e:
        return f"Error rendering template: {e}", 500


if __name__ == "__main__":
    app.run(debug=True)
