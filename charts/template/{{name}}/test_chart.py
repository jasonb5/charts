import pytest
import requests
from pathlib import Path
from selenium import webdriver


class TestChart:
    def setup_method(self, method):
        options = webdriver.FirefoxOptions()
        options.add_argument("-headless")

        self.driver = webdriver.Firefox(options)
        self.vars = {}
        self.driver.set_window_size(1920, 1080)
        self.image_dir = Path(".", "images").absolute()

    def teardown_method(self, method):
        self.driver.quit()

    @pytest.mark.parametrize("url,image_name", [
    ])
    def test_capture_screenshot(self, url, image_name):
        if url is None:
            url = "http://127.0.0.1:8080"
        elif url.startswith("/"):
            url = f"http://127.0.0.1:8080{url}"

        self.driver.get(url)

        image_path = self.image_dir / image_name

        image_path = image_path.with_suffix(".png")

        self.driver.save_screenshot(self.image_dir / image_name)

    @pytest.mark.parametrize("url,status_codes", [
        (None, (200,)),
    ])
    def test_url(self, url, status_codes):
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
