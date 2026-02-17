-- Create different user roles
CREATE ROLE student_readonly LOGIN PASSWORD 'student123';
CREATE ROLE student_analyst LOGIN PASSWORD 'analyst123';
CREATE ROLE admin_user LOGIN PASSWORD 'admin123';

-- Grant read-only access
GRANT CONNECT ON DATABASE gameverse TO student_readonly;
GRANT USAGE ON SCHEMA public TO student_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO student_readonly;

-- Grant read and limited write access
GRANT CONNECT ON DATABASE gameverse TO student_analyst;
GRANT USAGE ON SCHEMA public TO student_analyst;
GRANT SELECT, INSERT, UPDATE ON reviews, user_library TO student_analyst;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO student_analyst;

-- Grant full access
GRANT ALL PRIVILEGES ON DATABASE gameverse TO admin_user;