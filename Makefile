all:setup

setup:requirements.txt
	@clear
	@echo "Ensure virtual environment is activated"
	@pip install -r requirements.txt
	@pre-commit install
	@pre-commit run --all-files