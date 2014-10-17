require 'nokogiri'

$Ecu = "Keko"
@Delta = 10

def getUniqueVarName(param)
	return "VAR_" + param[:PRM_shortname] + param[:PRM_dop]
end

def generateTestModule(did_array)

	

	builder = Nokogiri::XML::Builder.new do |xml|
	  xml.testmodule(	'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
						'xmlns'     => 'http://www.vector-informatik.de/CANoe/TestModule/1.15',
						'xsi:schemaLocation' => 'http://www.vector-informatik.de/CANoe/TestModule/1.15 testmodule.xsd',
						:title 		=> "Toyota Tests",
						:version	=> "1.0") {
		xml.description 'Autogenerated Test to test Toyota DID Read and Write Diag Services'
		xml.preparation {
			did_array.each { |did|
				did[:DID_params].each { |param| 
					xml.vardef('0', :name => getUniqueVarName(param), :type => "int")
				}
			}
		}
		xml.testgroup(:title => 'Read and Write Parameters') {
			did_array.each { |did|
				xml.testcase(:ident => "#{did[:DID_name]}_Read", :title => "0x#{did[:DID_id].to_i.to_s(16).upcase}: #{did[:DID_name]}_Read") {
					xml.diagservice(:title => "#{did[:DID_name]}_Read", :result => "pos", :ecu => $Ecu, :service => "#{did[:DID_name]}_Read") {
						xml.diagrequest
						xml.diagresponse {
							did[:DID_params].each { |param|
								if not param[:PRM_isArray] then
									xml.diagparam(:qualifier => param[:PRM_shortname], :copytovar => getUniqueVarName(param))	{
										xml.var(:name => getUniqueVarName(param))
									}
								end
							}
						}
					}
					did[:DID_params].each { |param|
						if not param[:PRM_isArray] then
							xml.varset_bycapl(:name => getUniqueVarName(param)) {
								xml.caplfunction { 
									xml.cdata("#{getUniqueVarName(param)} = #{getUniqueVarName(param)} + delta;")
								}
								xml.caplparam("#{@Delta}", :name => "delta", :type => "int")
							}
						end
					}
					if did[:DID_rw].include? "Write" then
						xml.diagservice(:title => "#{did[:DID_name]}_Write", :result => "pos", :ecu => $Ecu, :service => "#{did[:DID_name]}_Write") {
							xml.diagrequest {
								did[:DID_params].each { |param|
									if not param[:PRM_isArray] then
										xml.diagparam(:qualifier => param[:PRM_shortname])	{
											xml.var(:name => getUniqueVarName(param))
										}
									end
								}
							}
							xml.diagresponse
						}
						xml.diagservice(:title => "#{did[:DID_name]}_Read", :result => "pos", :ecu => $Ecu, :service => "#{did[:DID_name]}_Read") {
							xml.diagrequest
							xml.diagresponse {
								did[:DID_params].each { |param|
									if not param[:PRM_isArray] then
										xml.diagparam(:qualifier => param[:PRM_shortname])	{
											xml.var(:name => getUniqueVarName(param))
										}
									end
								}
							}
						}
					end
				}
			}
		}
	 }
	end
	
	#puts builder.to_xml
	#puts did_array[0]

	return builder.to_xml
	
end