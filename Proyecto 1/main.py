"""Runner del ETL (Champions y Mundial)."""

"""Importación para ejecutar el ETL desde la línea de comandos."""
import argparse 

"""Importación para acceder a los módulos de ETL."""
from scripts import etl_champions, etl_extras, etl_worldcup 


"""Parsea los argumentos de la línea de comandos para determinar qué dataset procesar."""
def parse_args() -> argparse.Namespace:
	parser = argparse.ArgumentParser(description="Ejecuta ETL de Champions y/o Mundial")
	parser.add_argument(
		"--dataset",
	choices=["champions", "worldcup", "extras", "all"],#limita a elegir un dataset específico o procesar todos
		default="champions"
	)
	return parser.parse_args()

"""Arma la lógica para ejecutar el ETL según el dataset seleccionado en los argumentos de la línea de comandos."""
if __name__ == "__main__":
	args = parse_args()
	if args.dataset == "champions":
		etl_champions.main()
	elif args.dataset == "worldcup":
		etl_worldcup.main()
	elif args.dataset == "extras":
		etl_extras.main()
	else:
		etl_champions.main()
		etl_worldcup.main()
		etl_extras.main()
