drop table news_story_category;
drop table news_story;
drop table news_category;

create table news_story (
        news_story_id serial primary key,
        headline text not null,
        body text not null,
        date timestamp with time zone not null default now(),
        unique( headline, date )
);

create table news_category (
        news_category_id serial primary key,
        short_name varchar(80),
        long_name text,
        unique( short_name )
);

create table news_story_category (
        news_story_id int references news_story on delete cascade,
        news_category_id int references news_category on delete cascade
);

