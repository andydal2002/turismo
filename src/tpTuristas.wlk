object milla {
	var property cotizacion = 100 // $100
}

class Turista {
	var property millas
	var property edad
	var property preferencias = []
	
	method cumplirAnios() { edad += 1 }
	
	method dinero() = millas * milla.cotizacion()
	
	method acreditarMillas(cantMillas) { millas += cantMillas }
	method descontarMillas(cantMillas) { millas -= cantMillas }
	
	method visitar(sitio) { sitio.registrarTurista(self) }
	
	method todosLosSitiosQuePuedeVisitar() = pais.sitios().filter{sitio => sitio.dejarPasar(self)}
	method visitoAlMenosUnaAtraccion() = pais.sitios().any{sitio => sitio.turistas().contains(self) }
	
	method prefiere(categoria) = preferencias.contains(categoria)
	
	method penalizar() { 
		preferencias.forEach{pref => self.efectuarPenalidad(pref) }
	}
	
	method efectuarPenalidad(categoria) {
		if(self.nuncaVisito(categoria)) self.descontarMillas(10 * categoria.millas())
	}
	
	method nuncaVisito(categoria) =
		not pais.sitios().any{sitio => sitio.categoria() == categoria && sitio.estaRegistrado(self)}
}

class Sitio {
	var property turistas = []
	var costoEntrada
	var property categoria 
	
	method dejarPasar(turista) = turista.dinero() >= costoEntrada 
	
	method registrarTurista(turista) {
		if(not self.dejarPasar(turista)) self.error("El turista no tiene suficiente dinero")
		turistas.add(turista)
		turista.descontarMillas(self.costoEnMillas())
	}
	method costoEnMillas() = costoEntrada / milla.cotizacion()
	
	method cantMenores() = turistas.filter{turista => turista.edad() < 18}.size()
	
	method estaRegistrado(turista) = turistas.contains(turista)
	
	method darMillaA(turista) {
		if(turista.prefiere(categoria)) turista.acreditarMillas(categoria.millas())
	}
}

class SitioInfantil inherits Sitio {
	override method dejarPasar(turista) = super(turista) && turista.edad() < 18
	override method registrarTurista(turista) {
		if(turista.edad() > 18) self.error("El turista no es menor de edad")
		super(turista)
		turista.acreditarMillas(10)
	}
}

class SitioMayores inherits Sitio {
	var descuento
	
	override method dejarPasar(turista) =
	if(turista.edad() < 70) super(turista)
	else turista.dinero() >= costoEntrada - (costoEntrada * descuento)
	
	override method costoEnMillas() = ( costoEntrada - (costoEntrada * descuento) ) / milla.cotizacion()
}

object pais {
	var property turistas = []
	var property sitios = []
	
	method pasarUnAnio() { turistas.forEach{turista => turista.cumplirAnios()} }
	
	method agregarTurista(turista) { turistas.add(turista) }
	method agregarSitio(sitio) { sitios.add(sitio) }
	
	method sitioMasVisitadoPorMenores() = sitios.max{sitio => sitio.cantMenores() }
	
	method repartirMillas() { turistas.forEach{turista => self.repartirA(turista)} }
	
	method repartirA(turista) {
		const sitiosVisitados = sitios.filter{sitio => sitio.estaRegistrado(turista)}
		sitiosVisitados.forEach{sitio => sitio.darMillaA(turista)}
		turista.penalizar()
	}
	
}

class SitioVip inherits Sitio {
	override method registrarTurista(turista) {
		super(turista)
		turista.acreditarMillas(turista.edad() * 2)
	}
}

class Categoria {
	var property millas
}

const museo = new Categoria(millas = 10)
const parque = new Categoria(millas = 20)
const monumento = new Categoria(millas = 5)