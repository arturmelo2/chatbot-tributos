from app import app


def test_health_smoke():
    client = app.test_client()
    resp = client.get("/health")
    # We don't assert 200 because health may fail if LLM config is missing.
    assert resp.status_code in (200, 503)
    data = resp.get_json()
    assert isinstance(data, dict)
    assert "status" in data
