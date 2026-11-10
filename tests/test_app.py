import pytest

from app import create_app


@pytest.fixture
def client():
    app = create_app()
    app.config["TESTING"] = True
    return app.test_client()


def test_home_page(client):
    response = client.get("/")
    assert response.status_code == 200
    assert b"SecureDeploy" in response.data


def test_health_status_code(client):
    response = client.get("/health")
    assert response.status_code == 200


def test_health_response_body(client):
    response = client.get("/health")
    data = response.get_json()
    assert data["status"] == "healthy"
    assert data["application"] == "SecureDeploy"
