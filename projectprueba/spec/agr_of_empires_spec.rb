require 'rspec'
require_relative '../src/age_of_empires'

describe 'Age of Empires' do

  let(:un_guerrero) {
    Guerrero.new(100, 200)
  }

  let(:otro_guerrero) {
    Guerrero.new(200, 50)
  }

  it 'un guerrero deberia atacar a otro guerrero' do
    un_guerrero.atacar(otro_guerrero)
    expect(otro_guerrero.energia).to eq(950)
  end

  it 'un espadachin deberia atacar a otro guerrero' do
    espadachin = Espadachin.new(200, 50)
    espadachin.espada = Espada.new(150)
    espadachin.atacar(otro_guerrero)
    expect(otro_guerrero.energia).to eq(700)
  end

  it 'un misil ataca a un guerrero' do
    misil = Misil.new
    misil.atacar(otro_guerrero)
    expect(otro_guerrero.energia).to eq(450)
  end

  it 'un misil ataca a una muralla' do
    misil = Misil.new
    muralla = Muralla.new
    misil.atacar(muralla)
    expect(muralla.energia).to eq(1000)
  end
end