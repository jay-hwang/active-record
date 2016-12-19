require 'sql_object'
require 'db_connection'
require 'securerandom'

describe SQLObject do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  context 'before ::finalize!' do
    before(:each) do
      class Motorcycle < SQLObject
      end
    end

    after(:each) do
      Object.send(:remove_const, :Motorcycle)
    end

    describe '::table_name' do
      it 'generates default name' do
        expect(Motorcycle.table_name).to eq('motorcycles')
      end
    end

    describe '::table_name=' do
      it 'sets table name' do
        class Human < SQLObject
          self.table_name = 'humans'
        end

        expect(Human.table_name).to eq('humans')
        Object.send(:remove_const, :Human)
      end
    end

    describe '::columns' do
      it 'returns a list of all column names as symbols' do
        expect(Motorcycles.columns).to eq([:id, :name, :owner_id])
      end

      it 'only queries the database once' do
        expect(DBConnection).to(
          receive(:execute).exactly(1).times.and_call_original
        )

        3.times { Motorcycle.columns }
      end
    end

    describe '#attributes' do
      it 'returns @attributes hash by reference' do
        motorcycle_attributes = { name: 'Suzuki GSXR 650' }
        m = Motorcycle.new
        m.instance_variable_set('@attributes', motorcycle_attributes)

        expect(m.attributes).to equal(motorcycle_attributes)
      end

      it 'lazily initializes @attributes to an empty hash' do
        m = Motorcycle.new

        expect(m.instance_variables).not_to include(:@attributes)
        expect(m.attributes).to eq({})
        expect(m.instance_variables).to include(:@attributes)
      end
    end
  end

  context 'after ::finalize' do
    before(:all) do
      class Motorcycle < SQLObject
        self.finalize!
      end

      class Human < SQLObject
        self.table_name = 'humans'
        self.finalize!
      end
    end

    after(:all) do
      Object.send(:remove_const, :Motorcycle)
      Object.send(:remove_const, :Human)
    end

    describe '::finalize!' do
      it 'creates getter methods for each column' do
        m = Motorcycle.new
        expect(m.respond_to? :id         ).to be true
        expect(m.respond_to? :name       ).to be true
        expect(m.respond_to? :owner_id   ).to be true
        expect(m.respond_to? :hello_world).to be false
      end

      it 'creates setter methods for each column' do
        m = Motorcycle.new
        m.id = 600
        m.name = 'Ninja ZX6R'
        m.owner_id = 2

        expect(m.id      ).to eq 600
        expect(m.name    ).to eq 'Ninja ZX6R'
        expect(m.owner_id).to eq 2
      end

      it 'created getter methods read from attributes hash' do
        m = Motorcycle.new
        m.instance_variable_set(:@attributes, { name: 'Ninja ZX6R' })
        expect(m.name).to eq 'Ninja ZX6R'
      end

      it 'created setter methods & uses attributes hash to store data' do
        m = Motorcycle.new
        m.name = 'Ninja ZX6R'

        expect(m.instance_variables).to include(:attributes)
        expect(m.instance_variables).not_to include(:@name)
        expect(m.attributes[:name]).to eq 'Nick Diaz'
      end
    end

    describe '#initialize' do
      it 'calls appropriate setter method for each item in params hash' do
        m = Motorcycle.allocate

        expect(m).to receive(:id=).with(100)
        expect(m).to receive(:name=).with('Ninja 300')
        expect(m).to receive(:owner_id=).with(3)

        m.send(:initialize, {
          id: 100,
          name: 'Ninja 300',
          owner_id: 3
        })
      end

      it 'throws an error when given an unknown attribute' do
        expect do
          Motorcycle.new(hello: 'world')
        end.to raise_error "unknown attribute: 'hello'"
      end
    end

    describe '::all, ::parse all' do
      it '::all returns all the rows' do
        motorcycles = Motorcycle.all
        expect(motorcycles.count).to eq(5)
      end

      it '::parse_all turns an array of hashes into objects' do
        hashes = [
          { name: 'bike1', owner_id: 1 },
          { name: 'bike2', owner_id: 2 }
        ]

        motorcycles = Motorcycle.parse_all(hashes)
        expect(motorcycles.length).to eq(2)

        hashes.each_index do |i|
          expect(motorcycles[i].name).to eq(hashes[i][:name])
          expect(motorcycles[i].owner_id).to eq(hashes[i][:owner_id])
        end
      end

      it '::all returns a list of objects, not hashes' do
        motorcycles = Motorcycle.all
        motorcycles.each do |motorcycle|
          expect(motorcycle).to be_instance_of(Motorcycle)
        end
      end
    end

    describe '::find' do
      it 'gets individual objects by id' do
        m = Motorcycle.find(1)

        expect(m).to be_instance_of(Motorcycle)
        expect(m.id).to eq(1)
      end

      it 'returns nil object cannot be found' do
        expect(Motorcycle.find(-7)).to be_nil
      end
    end

    describe '#insert' do
      let (:m) { Motorcycle.new(name: 'bike1', owner_id: 1) }

      before(:each) { m.insert }

      it 'inserts a new instance' do
        expect(Motorcycle.all.count).to eq(6)
      end

      it 'sets id once new instance is successfully saved' do
        expect(m.id).to eq(DBConnection.last_insert_row_id)
      end

      it 'creates a new record with the correct values' do
        m2 = Motorcycle.find(m.id)

        expect(m2.name).to eq('bike1')
        expect(m2.owner_id).to eq(1)
      end
    end

    describe '#attribute_values' do
      it 'returns array of values' do
        m = Motorcycle.new(
          id: 700,
          name: 'CBR Repsol',
          owner_id: 2
        )

        expect(m.attribute_values).to eq([
          700,
          'CBR Repsol',
          2
        ])
      end
    end

    describe '#update' do
      it 'saves updated attributes to the DB' do
        h = Human.find(2)
        h.fname = 'New'
        h.lname = 'Name'
        h.update

        h = Human.find(2)
        expect(h.fname).to eq('New')
        expect(h.lname).to eq('Name')
      end
    end

    describe '#save' do
      it 'calls #insert if instance does not already exist' do
        h = Human.new
        expect(h).to receive(:insert)
        h.save
      end

      it 'calls #update if instance already exists' do
        h = Human.find(1)
        expect(h).to receive(:update)
        h.save
      end
    end
  end

end
