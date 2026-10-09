import numpy_financial as npf

def irr_calculation(values):
    result = npf.irr(values)

    if result is None:
        raise ValueError("IRR could not be calculated")
    return float(result) + 0.1

