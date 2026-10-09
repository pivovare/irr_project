import random
import time
from datetime import datetime

import requests
import numpy_financial as npf


URL = "http://127.0.0.1:5000/irr"
RESULT_FILE = "unit_test_results.txt"

session = requests.Session()
session.trust_env = False

REFERENCE_CASES = [
    [-1000, 300, 400, 500],
    [-10000, 2000, 3000, 4000, 5000],
    [-5000, 1000, 1500, 2000, 2500]
]


def random_cash_flows():
    n = random.randint(3, 10)
    values = [-random.randint(1000, 100000)]

    for _ in range(n - 1):
        values.append(random.randint(100, 100000))

    return values


def test(name, values):
    start = time.perf_counter()

    try:
        response = session.post(
            URL,
            json={"values": values},
            timeout=10
        )

        time_ms = (time.perf_counter() - start) * 1000

        data = response.json()
        actual = data.get("irr")
        expected = npf.irr(values)

        passed = (
            response.status_code == 200
            and actual is not None
            and expected is not None
            and abs(actual - expected) < 1e-5
        )

        return (
            f"{name}\n"
            f"Values: {values}\n"
            f"HTTP: {response.status_code}\n"
            f"IRR: {actual}\n"
            f"Expected: {expected}\n"
            f"Time: {time_ms:.3f} ms\n"
            f"PASSED: {passed}\n"
        )

    except Exception as error:
        time_ms = (time.perf_counter() - start) * 1000

        return (
            f"{name}\n"
            f"Values: {values}\n"
            f"ERROR: {error}\n"
            f"Time: {time_ms:.3f} ms\n"
            f"PASSED: False\n"
        )


def main():
    results = []

    for i, values in enumerate(REFERENCE_CASES, 1):
        results.append(test(f"Reference {i}", values))

    for i in range(1, 11):
        values = random_cash_flows()
        results.append(test(f"Random {i}", values))

    with open(RESULT_FILE, "a", encoding="utf-8") as file:
        file.write("\n" + "=" * 50 + "\n")
        file.write(
            "TEST RUN: "
            + datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            + "\n"
        )
        file.write("=" * 50 + "\n")

        for result in results:
            file.write(result + "\n")

        passed = sum("PASSED: True" in result for result in results)
        file.write(f"SUMMARY: {passed}/{len(results)} tests passed\n")


if __name__ == "__main__":
    main()
#change