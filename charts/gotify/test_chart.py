import time
import pytest
import requests
import subprocess
from pathlib import Path
from selenium import webdriver

@pytest.fixture(scope="session")
def selenium(kubernetes):
    options = webdriver.FirefoxOptions()
    options.add_argument("-headless")

    driver = webdriver.Firefox(options)
    driver.set_window_size(1920, 1080)

    yield driver

    driver.quit()

@pytest.fixture
def image_dir():
    pwd = Path.cwd()

    image_dir = pwd / "images"

    image_dir.mkdir(parents=True, exist_ok=True)

    return image_dir

@pytest.fixture(scope="session")
def kubernetes():
    port_forward = subprocess.Popen(["make", "open"])

    time.sleep(1)

    yield

    port_forward.terminate()

@pytest.mark.parametrize("url,image_name", [
    (None, "test"),
])
def test_capture_screenshot(url, image_name, selenium, image_dir):
    if url is None:
        url = "http://127.0.0.1:8080"
    elif url.startswith("/"):
        url = f"http://127.0.0.1:8080{url}"

    selenium.get(url)

    image_path = image_dir / image_name

    image_path = image_path.with_suffix(".png")

    time.sleep(1)

    selenium.save_screenshot(image_path)

@pytest.mark.parametrize("url,status_codes", [
    (None, (200,)),
])
def test_url(url, status_codes, kubernetes):
    if url is None:
        url = "http://127.0.0.1:8080"
    elif url.startswith("/"):
        url = f"http://127.0.0.1:8080{url}"

    response = requests.get(
        url,
        verify=False,
        timeout=2
    )

    assert response.status_code in status_codes
