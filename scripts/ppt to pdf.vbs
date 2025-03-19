
' Set the folder containing PowerPoint files (Change this path)

Dim pptApp, pptPresentation, fso, folder, file, inputFolder, outputPath

inputFolder = "C:\Users\bender\Desktop\H2EB\ActiveDirectory\docsBase\20410D - FR"

' Set the output folder for PDF handouts
outputPath = "C:\Users\bender\Desktop\H2EB\ActiveDirectory\docsBase\20410D - FR\handouts"


' Create FileSystemObject to iterate over files
Set fso = CreateObject("Scripting.FileSystemObject")
Set folder = fso.GetFolder(inputFolder)

' Create PowerPoint Application
Set pptApp = CreateObject("PowerPoint.Application")
pptApp.Visible = True ' Show PowerPoint (Optional)

' Loop through each PowerPoint file
For Each file In folder.Files
    If LCase(fso.GetExtensionName(file.Name)) = "pptx" Then
        ' Open Presentation
        Set pptPresentation = pptApp.Presentations.Open(file.Path, , , False)
        
        ' Print as "Notes Pages" instead of "Handouts"
        pptPresentation.PrintOptions.OutputType = 2 ' 2 = Notes Pages (Includes comments/notes)
        pptPresentation.PrintOptions.PrintInBackground = False

        ' Print to default printer ("Microsoft Print to PDF")
        pptPresentation.PrintOut

        ' Close Presentation
        pptPresentation.Close
    End If
Next

' Clean up
pptApp.Quit
Set pptApp = Nothing
Set pptPresentation = Nothing
Set folder = Nothing
Set fso = Nothing

MsgBox "Handouts with notes printed! Please choose save location in each prompt.", vbInformation, "Handout Export"