# TrabajoPLN

Buscador de enfermedades
Generar un buscador para el que, dada una noticia, documento o corpus, encuentre enfermedades clasificadas
por tipos. Los tipos que se contemplan son: dolor, alteración, infección o cáncer. Se pueden plantear nuevos
4 tipos de interés. La clasificación de estas enfermedades se realiza mediante los afijos utilizados en medicina:
_algia para dolor, hipo_/hiper_ para alteraciones, _itis para infección y _oma para cáncer.

La búsqueda debe contemplar que dichas palabras sean nombres (no adjetivos que tengan dichos afijos) y que
se pueda devolver el sintagma nominal completo que describa la enfermedad (e.g. fascitis necrosante). Por
último, devolver dicha enfermedad en su forma invariable/lema.


(Opcional) Buscar la definición de esa enfermedad en un diccionario médico.


Datasets:
Articulos médicos en español aquí
Un ejemplo de API REST que pueden explotar para el diccionario es https://www.cun.es/diccionario-
medico/terminos/abdominocentesis.
En general sería: https://www.cun.es/diccionario-medico/terminos/{CONCEPTO}
