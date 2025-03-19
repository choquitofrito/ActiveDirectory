from pdf2image import convert_from_path

def convert_pdf_to_images(pdf_path, output_folder):
    pages = convert_from_path(pdf_path)
    for i, page in enumerate(pages):
        page.save(f"{output_folder}/page_{i + 1}.png", "PNG")

pdf_path = "C:/Users/bender/Desktop/H2EB/ActiveDirectory/docsBase/20410D - FR/pdfs/12.pdf"
output_folder = "C:/Users/bender/Desktop/H2EB/ActiveDirectory/docsBase/20410D - FR/pdfs/images"
convert_pdf_to_images(pdf_path, output_folder)

