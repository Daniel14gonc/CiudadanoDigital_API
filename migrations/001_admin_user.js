import bcrypt from 'bcryptjs'

export async function up(pgm) {
  const adminEmail = process.env.ADMIN_EMAIL
  const adminPassword = process.env.ADMIN_PASSWORD

  if (!adminEmail || !adminPassword) {
    console.log('ADMIN_EMAIL o ADMIN_PASSWORD no definidos. Omitiendo creación de usuario admin.')
    return
  }

  const salt = await bcrypt.genSalt(10)
  const passwordHash = await bcrypt.hash(adminPassword, salt)

  pgm.sql(`
    INSERT INTO Usuario (email, names, lastnames, birthdate, phoneCode, phoneNumber, password, role)
    VALUES ('${adminEmail}', 'Admin', 'User', '2000-01-01', '502', '00000000', '${passwordHash}', 'admin')
    ON CONFLICT (email) DO NOTHING;
  `)
}

export async function down(pgm) {
  const adminEmail = process.env.ADMIN_EMAIL

  if (!adminEmail) {
    return
  }

  pgm.sql(`
    DELETE FROM Usuario WHERE email = '${adminEmail}' AND role = 'admin';
  `)
}
