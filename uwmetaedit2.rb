#!/usr/bin/env ruby

require 'flammarion'
require 'yaml'
require 'mediainfo'
require 'pry'

# Check for windows
if Gem.win_platform?
  windows = true
else
  windows = false
end

#Set up/Load config
scriptPath = __dir__
configPath = scriptPath + "/uw-metaedit-config.txt"
unless File.exist?(configPath)
  configBlank = {
    "originator" =>'Originator',
    "history1" => 'Encoding History Line 1',
    "history2" => 'Encoding History Line 2',
    "collection" => 'Collection Number(s)'
  }
  binding.pry
  File.open(configPath, "w") { |file| file.write(configBlank.to_yaml) }
end

 configOptions = YAML.load(File.read(configPath))

def getOutputDir()
  if windows
    @outputDir = `powershell "Add-Type -AssemblyName System.windows.forms|Out-Null;$f=New-Object System.Windows.Forms.FolderBrowserDialog;$f.SelectedPath = 'C:\';$f.Description = 'Select Output Directory';$f.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true }))|Out-Null;$f.SelectedPath"`.strip + '\\'
  else
    @outputDir = `zenity --file-selection --directory`.strip + '/'
  end
end

def getDerivDir()
  if windows
    derivDir = `powershell "Add-Type -AssemblyName System.windows.forms|Out-Null;$f=New-Object System.Windows.Forms.FolderBrowserDialog;$f.SelectedPath = 'C:\';$f.Description = 'Select Output Directory';$f.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true }))|Out-Null;$f.SelectedPath"`.strip + '\\'
  else
    derivDir = `zenity --file-selection --directory`.strip + '/'
  end
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
  origin = window.pane("BEXT").input(originator, options = {value:originator})
  codeHist1 = window.pane("BEXT").input(history1, options = {value:history1})
  codeHist2 = window.pane("BEXT").input(history2, options = {value:history2})
  window.pane("Items").orientation = :horizontal
  window.pane("Items").puts("Item Info", replace:true)
  collNumber = window.pane("Items").input(collection, options = {value:collection})
  window.pane("Items").input("Item Number")
  window.pane("Items").button("Save Settings") {
    configOptions['originator'] = origin.to_s
    configOptions['history1'] = codeHist1.to_s
    configOptions['history2'] = codeHist2.to_s
    configOptions['collection'] = collNumber.to_s
    File.open(configPath, "w") { |file| file.write(configOptions.to_yaml) }
   }
  window.wait_until_closed
end