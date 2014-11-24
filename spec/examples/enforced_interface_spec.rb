require 'spec_helper'

describe EnforcedInterface do

  module TestInterface
    def add(one, two)
      # Interface method - to be implemented
    end
  end

  context 'when matching method perfectly' do

    shared_examples_for 'a working interface' do

      it 'should allow method calls' do
        expect(klass.new.add(1, 2)).to eq(3)
      end

      it 'should include the module' do
        expect(klass.new).to be_a(TestInterface)
      end

      it 'should not pollute' do
        expect { Class.new.new }.not_to raise_error
        expect { Class.new.tap { |c| c.send(:include, Module.new) }.new }.not_to raise_error
      end

    end

    2.times do # follow-up usage for caching
      context 'when using the interface properly' do
        let(:klass) do
          Class.new do
            def add(one, two)
              3
            end
            include EnforcedInterface[TestInterface]
          end
        end

        it_should_behave_like 'a working interface'
      end
    end

  end

  context 'when matching but with wrong arity' do

    let(:klass) do
      Class.new do
        def add(one)
        end
        include EnforcedInterface[TestInterface]
      end
    end

    it 'should error and show wrong arity' do
      expect { klass }.to raise_error(EnforcedInterface::NotImplementedError) do |err|
        expect(err.message).to end_with('supports public instance method add with incorrect arity')
      end
    end

  end

  context 'when matching but with wrong access' do

    let(:klass) do
      Class.new do
        private
        def add(one)
        end
        include EnforcedInterface[TestInterface]
      end
    end

    it 'should error and show not implemented' do
      expect { klass }.to raise_error(EnforcedInterface::NotImplementedError) do |err|
        expect(err.message).to end_with('does not support public instance method add')
      end
    end

  end

  context 'when not implemented' do

    let(:klass) do
      Class.new do
        include EnforcedInterface[TestInterface]
      end
    end

    it 'should error and show not implemented' do
      expect { klass }.to raise_error(EnforcedInterface::NotImplementedError) do |err|
        expect(err.message).to end_with('does not support public instance method add')
      end
    end

  end

end
