from flask import Blueprint, jsonify

main = Blueprint("main", __name__)


@main.route("/")
def home():
    return (
        "<h1>SecureDeploy</h1>"
        "<p>A DevSecOps demo: tested, scanned, containerized, deployed.</p>"
    )


@main.route("/health")
def health():
    return jsonify(status="healthy", application="SecureDeploy")
