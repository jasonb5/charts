import sys
import time
import pytest
import requests
import subprocess
from pathlib import Path
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions
from selenium.webdriver.support.wait import WebDriverWait


sys.path.insert(0, str(Path.cwd()))

print(sys.path)

from test_config import *


def wait_until_visible(driver, locator, timeout):
    cond = expected_conditions.visibility_of_element_located(locator)
    wait = WebDriverWait(driver, timeout)
    wait.until(cond)


def wait_until_visible_css(driver, selector, timeout):
    wait_until_visible(driver, (By.CSS_SELECTOR, selector), timeout)


def wait(driver, css_selector=None, timeout=30):
    if css_selector is not None:
        wait_until_visible_css(driver, css_selector, timeout)


@pytest.fixture(scope="session")
def port_forward():
    p = subprocess.Popen(["make", "open"])

    time.sleep(1)

    try:
        yield
    except Exception:
        pass

    p.terminate()


@pytest.fixture(scope="session")
def driver(port_forward):
    options = webdriver.FirefoxOptions()
    options.add_argument("-headless")

    d = webdriver.Firefox(options)
    d.set_window_size(1920, 1080)

    try:
        yield d
    except Exception:
        pass

    d.quit()


def output_image_path(name):
    pwd = Path.cwd()

    image_path = pwd / "images" / name

    image_path.parent.mkdir(parents=True, exist_ok=True)

    return image_path.with_suffix(".png")


@pytest.mark.parametrize("path,name,navigate", SCREENSHOTS)
def test_capture_screenshot(path, name, navigate, driver):
    url = f"http://127.0.0.1:8080{path}"

    driver.get(url)

    if navigate is not None:
        navigate(driver, wait)

    image_path = output_image_path(name)

    driver.save_screenshot(image_path)


@pytest.mark.parametrize("path,params,data,headers,auth,timeout,allow_redirects", TESTS)
def test_url(path, params, data, headers, auth, timeout, allow_redirects, port_forward):
    url = f"http://127.0.0.1:8080{path}"

    response = requests.get(
        url,
        verify=False,
        params=params,
        data=data,
        headers=headers,
        auth=auth,
        timeout=timeout,
        allow_redirects=allow_redirects,
    )

    response.raise_for_status()
