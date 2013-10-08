requires 'perl', '5.008001';
requires 'Class::Accessor::Lite';
requires 'SQL::Maker';
requires 'DBIx::Sunny';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'File::Spec';
    requires 'File::Basename';
};
