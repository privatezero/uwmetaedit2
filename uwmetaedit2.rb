#!/usr/bin/env ruby

require 'flammarion'
require 'yaml'
require 'mediainfo'
require 'pry'

# Check for windows
if Gem.win_platform?
  Windows = true
else
  Windows = false
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
  if Windows
    targetFile = `powershell "Add-Type -AssemblyName System.windows.forms|Out-Null;$f=New-Object System.Windows.Forms.FolderBrowserDialog;$f.SelectedPath = 'C:\';$f.Description = 'Select Output Directory';$f.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true }))|Out-Null;$f.SelectedPath"`.strip + '\\'
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
  command << "--Description=#{collNumber}"
  command << "--OriginatorReference=#{File.basename(targetFile)}"
  command << "--History=#{history}"
  command << "--IARL=#{origin}"
  command << "--OriginationDate=#{moddate}"
  command << "--OriginationTime=#{modtime}"
  command << '--MD5-Embed'
  command << "#{targetFile}"
  system(*command)
end


# Set up config variables
originator = configOptions['originator']
history1 = configOptions['history1']
history2 = configOptions['history2']
collection = configOptions['collection']

if ARGV.length.positive?
  puts 'HELLO WORLD'
else
  window = Flammarion::Engraving.new
  window.image("")
  window.title("Welcome to UW Metaedit 2.0")
  window.pane("BEXT").puts("BEXT Info", replace:true)
  origin = window.pane("BEXT").input('Originator', options = {value:originator})
  codeHist1 = window.pane("BEXT").input('Encoding History Line 1' , options = {value:history1})
  codeHist2 = window.pane("BEXT").input('Encoding History Line 2', options = {value:history2})
  window.pane("Items").orientation = :horizontal
  window.pane("Items").puts("Item Info", replace:true)
  collNumber = window.pane("Items").input('Collection Number(s)', options = {value:collection})
  itemNumber = window.pane("Items").input('Item Number')
  window.pane("Items").button("Save Settings") {
    configOptions['originator'] = origin.to_s
    configOptions['history1'] = codeHist1.to_s
    configOptions['history2'] = codeHist2.to_s
    configOptions['collection'] = collNumber.to_s
    File.open(configPath, "w") { |file| file.write(configOptions.to_yaml) }
   }
  targetFile = window.pane("Items").button('Select Target') { targetFile = getOutputDir() }
  window.pane("Items").button('Embed Metadata') { embedBext(targetFile, origin, codeHist1, codeHist2, collNumber, itemNumber) }
  window.wait_until_closed
end