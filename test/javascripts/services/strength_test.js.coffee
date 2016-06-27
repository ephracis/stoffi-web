describe "evaluateStrengthService", ->
  evaluateStrength = null
  beforeEach module('Stoffi')
   
  beforeEach( () ->
    inject( ($injector) ->
      evaluateStrength = $injector.get 'evaluateStrength'
    )
  )
  
  # The following tests assumes 4 bots able to guess 25 password per second.
  # This is set in support/global.js
   
  it "should evalute lower case", ->
    evaluateStrength('foo').should.equal 'Can be guessed in 3 minutes.'
   
  it "should evalute upper case", ->
    evaluateStrength('BA').should.equal 'Can be guessed in 6 seconds.'
   
  it "should evalute numbers", ->
    evaluateStrength('1').should.equal 'Can be guessed in less than a second.'
   
  it "should evalute mixed case", ->
    evaluateStrength('Hello').should.equal 'Can be guessed in 5 weeks.'
   
  it "should evalute alphanum", ->
    evaluateStrength('Foo1').should.equal 'Can be guessed in 2 days.'
   
  it "should evalute alphanum and special characters", ->
    evaluateStrength('Foo1!').should.equal 'Can be guessed in about 1 year.'
   
  it "should evalute complex password", ->
    evaluateStrength('Foobar123!#').should.equal "Can't be guessed in a reasonable time."
  
describe 'PasswordEvaluator instance', ->
  it 'should set password', ->
    pe = new PasswordEvaluator 'mysecret'
    pe.password.should.equal 'mysecret'
    
  describe 'keyspace', ->
    
    it 'should handle lower case', ->
      pe = new PasswordEvaluator 'mysecret'
      pe.keyspace().should.equal 25
    
    it 'should handle upper case', ->
      pe = new PasswordEvaluator 'MYSECRET'
      pe.keyspace().should.equal 25
    
    it 'should handle numbers', ->
      pe = new PasswordEvaluator '123'
      pe.keyspace().should.equal 10
    
    it 'should handle special characters', ->
      pe = new PasswordEvaluator '!@#'
      pe.keyspace().should.equal 20
    
    it 'should handle mixed case', ->
      pe = new PasswordEvaluator 'MySecret'
      pe.keyspace().should.equal 25+25
    
    it 'should handle alphanum', ->
      pe = new PasswordEvaluator 'MySecret123'
      pe.keyspace().should.equal 25+25+10
    
    it 'should handle alphanum and special characters', ->
      pe = new PasswordEvaluator 'MySecret123!'
      pe.keyspace().should.equal 25+25+10+20
    
    it 'should handle mixed case and special characters', ->
      pe = new PasswordEvaluator 'MySecret!'
      pe.keyspace().should.equal 25+25+20
      
  describe 'humanTime', ->
    pe = new PasswordEvaluator 'mysecret'
    
    it 'should handle null', ->
      time = pe.humanTime()
      time[0].should.equal 0
      time[1].should.equal 'seconds'
    
    it 'should handle zero seconds', ->
      time = pe.humanTime(0)
      time[0].should.equal 0
      time[1].should.equal 'seconds'
    
    it 'should handle one second', ->
      time = pe.humanTime(1)
      time[0].should.equal 1
      time[1].should.equal 'seconds'
    
    it 'should handle three seconds', ->
      time = pe.humanTime(3)
      time[0].should.equal 3
      time[1].should.equal 'seconds'
    
    it 'should handle 1.5 minutes', ->
      time = pe.humanTime(90)
      time[0].should.equal 1.5
      time[1].should.equal 'minutes'
    
    it 'should handle three minutes', ->
      time = pe.humanTime(180)
      time[0].should.equal 3
      time[1].should.equal 'minutes'
    
    it 'should handle 1.5 hours', ->
      time = pe.humanTime(60*60*1.5)
      time[0].should.equal 1.5
      time[1].should.equal 'hours'
    
    it 'should handle three hours', ->
      time = pe.humanTime(60*60*3)
      time[0].should.equal 3
      time[1].should.equal 'hours'
    
    it 'should handle 1.5 days', ->
      time = pe.humanTime(60*60*24*1.5)
      time[0].should.equal 1.5
      time[1].should.equal 'days'
    
    it 'should handle 2 weeks', ->
      time = pe.humanTime(60*60*24*14)
      time[0].should.equal 2
      time[1].should.equal 'weeks'
    
    it 'should handle 3 months', ->
      time = pe.humanTime(60*60*24*90)
      time[0].should.equal 3
      time[1].should.equal 'months'
    
    it 'should handle 2 years', ->
      time = pe.humanTime(60*60*24*365*2)
      time[0].should.equal 2
      time[1].should.equal 'years'
    
    it 'should handle 50 years', ->
      time = pe.humanTime(60*60*24*365*50)
      time[0].should.equal 50
      time[1].should.equal 'years'
    
    it 'should handle 2 centuries', ->
      time = pe.humanTime(60*60*24*365*100*2)
      time[0].should.equal 2
      time[1].should.equal 'centuries'
    
    it 'should handle 50 centuries', ->
      time = pe.humanTime(60*60*24*365*100*50)
      time[0].should.equal 50
      time[1].should.equal 'centuries'
      
  describe 'crackTimeText', ->
    pe = new PasswordEvaluator 'mysecret'
    
    it 'should translate 0 seconds', ->
      pe.crackTimeText(0, 'seconds').should.equal 'Can be guessed in 0 seconds.'
    
    it 'should translate 1 second', ->
      pe.crackTimeText(1, 'seconds').should.equal 'Can be guessed in 1 second.'
    
    it 'should translate 5 minutes', ->
      pe.crackTimeText(5, 'minutes').should.equal 'Can be guessed in 5 minutes.'
    
    it 'should translate 3 hours', ->
      pe.crackTimeText(3, 'hours').should.equal 'Can be guessed in about 3 hours.'
    
    it 'should translate 3 days', ->
      pe.crackTimeText(3, 'days').should.equal 'Can be guessed in 3 days.'
    
    it 'should translate 3 weeks', ->
      pe.crackTimeText(3, 'weeks').should.equal 'Can be guessed in 3 weeks.'
    
    it 'should translate 3 months', ->
      pe.crackTimeText(3, 'months').should.equal 'Can be guessed in 3 months.'
    
    it 'should translate 48 years', ->
      pe.crackTimeText(48, 'years').should.equal 'Can be guessed in about 48 years.'
    
    it 'should translate 3 centuries', ->
      pe.crackTimeText(3, 'centuries').should.equal 'Can be guessed in 3 centuries.'