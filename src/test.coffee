chai = require 'chai'
csonschema = require 'csonschema'
request = require 'request'
_ = require 'underscore'
async = require 'async'

assert = chai.assert
chai.use(require 'chai-json-schema')


String::contains = (it) ->
  @indexOf(it) != -1

class Test
  constructor: () ->
    @name = ''
    @skip = false

    @request =
      server: ''
      path: ''
      method: 'GET'
      params: {}
      query: {}
      headers: {}

    @response =
      status: ''
      schema: null
      headers: null
      body: null

  url: () ->
    req = @request
    return "#{req.protocol}://#{req.hostname}#{req.path}"

  run: (callback) ->
    url = @request.server + @request.path
    {method, headers} = @request
    assertResponse = @assertResponse

    options = {url, headers, method}

    async.waterfall [
      (callback) ->
        request options, (error, response, body) ->
          callback null, error, response, body
      ,
      (error, response, body, callback) ->
        assertResponse(error, response, body)
        callback()
    ], callback

  parseSchema: (source) =>
    if source.contains('$schema')
      #jsonschema
      # @response.schema = JSON.parse @response.schema
      JSON.parse source
    else
      csonschema.parse source
      # @response.schema = csonschema.parse @response.schema

  assertResponse: (error, response, body) =>
    assert.isNull error
    assert.isNotNull response

    # Status code
    assert.equal response.statusCode, @response.status

    # Body
    assert.isNotNull body
    schema = @parseSchema @response.schema
    assert.jsonSchema (JSON.parse body), schema

    # Update @response
    @response.body = JSON.parse body

module.exports = Test