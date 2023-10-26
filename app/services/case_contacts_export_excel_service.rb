# frozen_string_literal: true

# CaseContactsExportExcelService handles the conversion of case contact data to Excel format.
# It provides methods for exporting case contact information to Excel files.
require 'case_contacts_export_data_columns'

class CaseContactsExportExcelService
  attr_reader :case_contacts, :filtered_columns
  include CaseContactsExportDataColumns

  FONT_SIZE = 11
  LINE_PADDING = 10

  def initialize(case_contacts, filtered_columns = nil)
    @filtered_columns = filtered_columns || CaseContactsExportDataColumns.data_columns.keys

    @case_contacts = case_contacts.preload({ creator: :supervisor }, :contact_types, :casa_case)
  end

  def perform
    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(name: 'Case Contacts') do |sheet|
        sheet.add_row(filtered_columns.map(&:to_s).map(&:titleize))

        if case_contacts.present?
          wrap_style = p.workbook.styles.add_style(alignment: { wrap_text: true, vertical: :center })

          case_contacts.decorate.each do |case_contact|
            format_row(sheet, case_contact, wrap_style)
          end
          configure_case_contact_notes_width(sheet)
          sheet.rows.each_with_index do |row, index|
            infer_row_height(row) if index.positive?
          end
        end
      end
    end.to_stream.read
  end

  private

  def configure_case_contact_notes_width(sheet)
    case_contact_notes_index = filtered_columns.index(:case_contact_notes)

    if case_contact_notes_index
      sheet.column_info[case_contact_notes_index].width = 140
    end
  end

  def format_row(sheet, case_contact, wrap_style)
    row_data = CaseContactsExportDataColumns.data_columns(case_contact).slice(*filtered_columns).values
    row_data << ''
    sheet.add_row(row_data, style: wrap_style)
  end

  def infer_row_height(row)
    physical_lines = row.each_with_index.map do |cell, column_index|
      text = cell.value
      column_width = row.worksheet.column_info[column_index].width

      text_lines = text.to_s.lines
      text_lines.map { |line| (string_width(line, row, FONT_SIZE) / column_width.to_f).ceil }.sum
    end.max
    row.height = (physical_lines * FONT_SIZE) + LINE_PADDING
  end

  def string_width(string, row, font_size)
    font_scale = font_size / row.worksheet.workbook.font_scale_divisor
    (string.to_s.size + 3) * font_scale
  end
  
end
