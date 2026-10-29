class Feria {

	const puestos=#{}
	//1.1b
	method todosLosPuestosVisitables(visitante) = puestos.filter({puesto=> puesto.puedeUsar(visitante)})
	method uso(visitante) = puestos.any({puesto => puesto.uso(visitante)})
	method agregar(puesto) { puestos.add(puesto)}
	method cuantosApadrina(municipio) = puestos.count({puesto => puesto.municipio() == municipio})
	method municipios() = puestos.map({puesto => puesto.municipio()}).asSet()
	method promedioRecaudacion() = self.municipios().sum({municipio => municipio.recaudacion()}) / self.municipios().size()
	method menosRecaudador() = self.municipios().min({municipio => municipio.recaudacion()})
}

class Puesto {

	const property visitantes=#{}
	const property municipio
	//1.1.a
	method puedeUsar(visitante)	
	method uso(visitante) = visitantes.contains(visitante)
	
	method validarVisita(visitante) {
		if(not self.puedeUsar(visitante)) {
			self.error(visitante + " no puede usar " + self)
		}
	}
	method usar(visitante) {
		self.validarVisita(visitante)
		visitantes.add(visitante)
	}
}

class PuestoInfantil inherits Puesto {

	override method puedeUsar(visitante) = visitante.esMenor()
	
	override method usar(visitante) {
		super(visitante)
		visitante.ganar(10)
	}
}

class PuestoComercial inherits Puesto{

	const costo
	
	override method puedeUsar(visitante) = visitante.dinero() >= costo
	
	override method usar(visitante){
		super(visitante)
		visitante.pagar(costo)
	}
} 

class Impositivo inherits Puesto{

	override method puedeUsar(visitante) = municipio.puedePagarDeuda(visitante)
	
	override method usar(visitante){
		super(visitante)
		municipio.pagarDeuda(visitante)
	}
} 

class Visitante {
	
	var property edad
	var property municipio
	var property dinero
	var property deuda
	
	
	method pagarDeuda(valor) {
		dinero -= valor
		deuda -= valor
	}
	
	method pagar(costo) {
		dinero-=costo
	}
	
	method ganar(cuanto) {
		dinero +=cuanto
	}
	
	method esMenor() = edad < 18
	method esResidente(unMunicipio) =  municipio == unMunicipio
	method tieneDeuda() = self.deuda() > 0 
}

class Municipio{
	
	var property recaudacion=0
	
	method puedePagarDeuda(visitante) = visitante.tieneDeuda() and visitante.esResidente(self) and self.montoExigible(visitante) <= visitante.dinero()
	
    method pagarDeuda(visitante) {
        const monto = self.montoExigible(visitante)
        visitante.pagarDeuda(monto)
        recaudacion += monto
    }
	
	method montoExigible(visitante) = self.bruto(visitante) - self.prorrogable(visitante)
	method bruto(visitante) = visitante.deuda()
	method prorrogable(visitante) = if (visitante.edad() > self.edadProrroga()) self.bruto(visitante) * 0.1 else 0
	method edadProrroga() = 75
}

class MunicipioRelajado inherits Municipio {
	
	override method bruto(visitante) = visitante.deuda().min(visitante.dinero())
}

class MunicipioHiperRelajado inherits MunicipioRelajado {
	
	override method bruto(visitante) = super(visitante) * 0.80
	override method prorrogable(visitante) = super(visitante) * 2
	override method edadProrroga() = 60
}