import pytest
from app.app import app  

@pytest.fixture
def client():
    """Creates a test client for Flask app"""
    app.testing = True
    return app.test_client()

def test_home(client):
    """Test the home route"""
    response = client.get('/')
    assert response.status_code == 200
    assert response.data == b"Hello!"
