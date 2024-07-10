# Example navigation function
def navigate(driver, wait):
    wait(driver, css_selector=".animate-pulse")


# The values must be in the form (path, name, navigate).
# The navigate argument can be None or is a function taking a
# selenium driver and wait function, see example above.
SCREENSHOTS = [
    # ("", "root", None),
]


# The values must be in the form
# (path, params, data, headers, auth, timeout, allow_redirects).
# These values are passed to request's get function.
TESTS = [
    ("", {}, {}, {}, None, 2, False),
]

# Additional test functions can be defined and will be imported.
#
# List of available test fixtures
# - port_forward
# - driver
#
# port_forward will run kubectl port-forward at 127.0.0.1:8080
# driver will return a selenium driver

# def test_example(driver):
#     driver.get("http://127.0.0.1:8080")
