import argparse
from selenium import webdriver

def main(url, **_):
    options = webdriver.ChromeOptions()
    options.add_argument("--headless=new")

    driver = webdriver.Chrome(options=options)
    driver.set_window_size(1920, 1080)
    driver.get(url)
    driver.save_screenshot("screenshot.png")

parser = argparse.ArgumentParser()
parser.add_argument("url")

args = parser.parse_args()

main(**vars(args))
