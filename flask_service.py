from flask import Flask, request, jsonify

from irr_calc import irr_calculation

app = Flask(__name__)

@app.route("/irr", methods=["POST"])
def calculate_irr():
    try:
        data = request.get_json()

        if not data or "values" not in data:
            return jsonify({"error": "You must specify values"}), 400

        values = data["values"]

        if not isinstance(values, list):
            return jsonify({"error": "values must be a list"}), 400

        result = irr_calculation(values)

        return jsonify({"irr": result}), 200

    except Exception as error:
        return jsonify({"error": str(error)}), 400
    
@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok"}), 200

if __name__ == '__main__':
    app.run(host="127.0.0.1", port=5000, debug=False)