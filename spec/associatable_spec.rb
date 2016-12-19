require 'associatable'

describe 'AssocOptions' do
  describe 'BelongsToOptions' do
    it 'provides defaults' do
      options = BelongsToOptions.new('house')

      expect(options.primary_key).to eq(:id)
      expect(options.foreign_key).to eq(:house_id)
      expect(options.class_name).to eq('House')
    end

    it 'allows overrides' do
      options = BelongsToOptions.new(
        'owner',
        primary_key: :human_id,
        foreign_key: :human_id,
        class_name: 'Human'
      )

      expect(options.primary_key).to eq(:human_id)
      expect(options.foreign_key).to eq(:human_id)
      expect(options.class_name).to eq('Human')
    end
  end

  describe 'HasManyOptions' do
    it 'provides defaults' do
      options = HasManyOptions.new('motorcycles', 'Human')

      expect(options.primary_key).to eq(:id)
      expect(options.foreign_key).to eq(:human_id)
      expect(options.class_name).to eq('Motorcycle')
    end

    it 'allows overrides' do
      options = HasManyOptions.new(
        'motorcycles',
        'Human',
        primary_key: :human_id,
        foreign_key: :owner_id,
        class_name: 'Bike'
      )

      expect(options.primary_key).to eq(:human_id)
      expect(options.foreign_key).to eq(:owner_id)
      expect(options.class_name).to eq('Bike')
    end
  end

  describe 'AssocOptions' do
    before(:all) do
      class Motorcycle < SQLObject
        self.finalize!
      end

      class Human < SQLObject
        self.table_name = 'humans'
        self.finalize!
      end
    end

    it '#model_class returns class of assoc object' do
      options = BelongsToOptions.new('human')
      expect(options.model_class).to eq(Human)

      options = HasManyOptions.new('motorcycles', 'Human')
      expect(options.model_class).to eq(Motorcycle)
    end

    it '#table_name returns table name of assoc object' do
      options = BelongsToOptions.new('human')
      expect(options.table_name).to eq('humans')

      options = HasManyOptions.new('motorcycles', 'Human')
      expect(options.table_name).to eq('motorcycles')
    end
  end

  describe 'Associatable' do
    before(:each) { DBConnection.reset }
    after(:each) { DBConnection.reset }

    before(:all) do
      class Motorcycle < SQLObject
        belongs_to :human, foreign_key: :owner_id
        finalize!
      end

      class Human < SQLObject
        self.table_name = 'humans'

        has_many :motorcycles, foreign_key: :owner_id
        belongs_to :house

        finalize!
      end

      class House < SQLObject
        has_many :humans
        finalize!
      end
    end

    describe '#belongs_to' do
      let(:yamaha_r1) { Motorcycle.find(1) }
      let(:john) { Human.find(1) }

      it 'fetches `human` from `Motorcycle`' do
        expect(yamaha_r1).to respond_to(:human)
        human = yamaha_r1.human

        expect(human).to be_instance_of(Human)
        expect(human.fname).to eq('John')
      end

      it 'fetches `house` from `Human`' do
        expect(john).to respond_to(:house)
        house = john.house

        expect(house).to be_instance_of(House)
        expect(house.address).to eq('100 Market Street')
      end

      it 'returns nil if no assoc object' do
        homeless_amber = Human.find(5)
        expect(homeless_amber.house).to eq(nil)
      end
    end

    describe '#has_many' do
      let(:kelly) { Human.find(2) }
      let(:kelly_house) { House.find(1) }

      it 'fetches `motorcycles` from `Human`' do
        expect(kelly).to respond_to(:motorcycles)
        motorcycles = kelly.motorcycles
        m = motorcycles.first

        expect(motorcycles.length).to eq(2)
        expect(m).to be_instance_of(Motorcycle)
        expect(m.name).to eq('Suzuki Hayabusa')
      end

      it 'fetches `humans` from `House`' do
        expect(kelly_house).to respond_to(:humans)
        humans = kelly_house.humans

        expect(humans.length).to eq(2)
        expect(humans[0]).to be_instance_of(Human)
        expect(humans[0].fname).to eq('John')
      end

      it 'returns an empty array if no assoc objects' do
        motorcycleless_amber = Human.find(5)
        expect(motorcycleless_amber.motorcycles).to eq([])
      end
    end

    describe '::assoc_options' do
      it 'defaults to empty hash' do
        class TestClass < SQLObject
        end

        expect(TestClass.assoc_options).to eq({})
      end

      it 'stores `belongs_to` options' do
        motorcycle_assoc_options = Motorcycle.assoc_options
        human_options = motorcycle_assoc_options[:human]

        expect(human_options).to be_instance_of(BelongsToOptions)
        expect(human_options.primary_key).to eq(:id)
        expect(human_options.foreign_key).to eq(:owner_id)
        expect(human_options.class_name).to eq('Human')
      end

      it 'stores options separately for individual classes' do
        expect(Motorcycle.assoc_options).to have_key(:human)
        expect(Motorcycle.assoc_options).to_not have_key(:house)
        expect(Human.assoc_options).to have_key(:house)
        expect(Human.assoc_options).to_not have_key(:human)
      end
    end

    describe '#has_one_through' do
      before(:all) do
        class Motorcycle
          has_one_through :home, :human, :house
          self.finalize!
        end
      end

      let(:motorcycle) { Motorcycle.find(1) }
      it 'adds getter method' do
        expect(motorcycle).to respond_to(:home)
      end

      it 'fetches associated `home` for a `Motorcycle`' do
        house = motorcycle.home

        expect(house).to be_instance_of(House)
        expect(house.address).to eq('100 Market Street')
      end

    end
  end
end
