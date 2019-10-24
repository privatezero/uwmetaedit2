#!/usr/bin/env ruby

require 'flammarion'
require 'yaml'
require 'mediainfo'
require 'pry'

# Check for $windows
if Gem.win_platform?
  $windows = true
else
  $windows = false
end

#Set up/Load config
scriptPath = __dir__
configPath = scriptPath + "/uw-metaedit-config.txt"
unless File.exist?(configPath)
  configBlank = {
    "originator" =>'',
    "history1" => '',
    "history2" => '',
    "collection" => ''
  }
  File.open(configPath, "w") { |file| file.write(configBlank.to_yaml) }
end

 configOptions = YAML.load(File.read(configPath))

def getOutputDir()
  if $windows
    targetFile = `powershell "Add-Type -AssemblyName System.$windows.forms|Out-Null;$f=New-Object System.$windows.Forms.FolderBrowserDialog;$f.SelectedPath = 'C:\';$f.Description = 'Select Output Directory';$f.ShowDialog((New-Object System.$windows.Forms.Form -Property @{TopMost = $true }))|Out-Null;$f.SelectedPath"`.strip + '\\'
  else
    targetFile = `zenity --file-selection`.strip
  end
  return targetFile
end


def embedBext(targetFile, origin, codeHist1, codeHist2, collNumber, itemNumber)
  command = []
  moddatetime = File.mtime(targetFile)
  moddate = moddatetime.strftime("%Y-%m-%d")
  modtime = moddatetime.strftime("%H:%M:%S")
  history = codeHist1 + "\n" + codeHist2
  description = "Collection number: #{collNumber}, " + "Item Number: #{itemNumber}, " + "Original File Name #{File.basename('/home/weaver/Desktop/test.wav',".*")}"
  command << 'bwfmetaedit' 
  command << '--reject-overwrite'
  command << "--Originator=#{origin}"
  command << "--Description=Collection number: #{collNumber}, Item number #{itemNumber}"
  command << "--OriginatorReference=#{File.basename(targetFile)}"
  command << "--History=#{history}"
  command << "--IARL=#{origin}"
  command << "--OriginationDate=#{moddate}"
  command << "--OriginationTime=#{modtime}"
  command << '--MD5-Embed'
  command << "#{targetFile}"
  if system(*command) && Gui
    $window.alert("Embedding done")
  elsif Gui
    $window.alert("Error occurred - please double check file and settings")
  end
end


# Set up config variables
originator = configOptions['originator']
history1 = configOptions['history1']
history2 = configOptions['history2']
collection = configOptions['collection']

unless ARGV.length.positive?
  Gui = true
  $window = Flammarion::Engraving.new
  $window.image("")
  $window.title("Welcome to UW Metaedit 2.0")
  $window.pane("Items").orientation = :horizontal
  $window.pane("Items").puts("Item Info", replace:true)
  collNumber = $window.pane("Items").input('Collection Number(s)', options = {value:collection})
  itemNumber = $window.pane("Items").input('Item Number')
  $window.pane("Items").button("Save Settings") {
    configOptions['originator'] = origin.to_s
    configOptions['history1'] = codeHist1.to_s
    configOptions['history2'] = codeHist2.to_s
    configOptions['collection'] = collNumber.to_s
    File.open(configPath, "w") { |file| file.write(configOptions.to_yaml) }
   }
  targetFile = $window.pane("Items").button('Select Target') { targetFile = getOutputDir() }
  $window.pane("Items").button('Embed Metadata') { embedBext(targetFile, origin, codeHist1, codeHist2, collNumber, itemNumber) }
  $window.pane("BEXT").puts("BEXT Info", replace:true)
  origin = $window.pane("BEXT").input('Originator', options = {value:originator})
  codeHist1 = $window.pane("BEXT").input('Encoding History Line 1' , options = {value:history1})
  codeHist2 = $window.pane("BEXT").input('Encoding History Line 2', options = {value:history2})
  $window.wait_until_closed
else
    Gui = false
    targetFile = ARGV[0]
    itemNumber = ARGV[1]
    binding.pry
    embedBext(targetFile, originator, history1, history2, collection, itemNumber)
end