require 'searchable'

describe 'Searchable' do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:all) do
    class Motorcycle < SQLObject
      finalize!
    end

    class Human < SQLObject
      self.table_name = 'humans'

      finalize!
    end
  end

  it '#where searches with single criterion' do
    motorcycles = Motorcycle.where(name: 'Honda CBR600rr')
    m = motorcycles.first

    expect(motorcycles.length).to eq(1)
    expect(m.name).to eq('Honda CBR600rr')
  end

  it '#where searches with multiple criteria' do
    humans = Human.where(fname: 'John', house_id: 1)
    expect(humans.length).to eq(1)

    human = humans.first
    expect(human.fname).to eq('John')
    expect(human.house_id).to eq(1)
  end

  it '#where can return multiple objects' do
    humans = Human.where(house_id: 1)
    expect(humans.length).to eq(2)
  end

  it '#where returns [] if there are no matches' do
    expect(Human.where(fname: 'hello', lname: 'world')).to eq([])
  end

end
