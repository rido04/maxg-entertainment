<?php

namespace App\Filament\Resources;

use Filament\Forms;
use Filament\Tables;
use Filament\Forms\Form;
use Filament\Tables\Table;
use App\Models\Advertisement;
use Filament\Resources\Resource;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Toggle;
use Filament\Forms\Components\Textarea;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\ToggleColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Filters\TernaryFilter;
use App\Filament\Resources\AdvertisementResource\Pages;

class AdvertisementResource extends Resource
{
    protected static ?string $model = Advertisement::class;

    protected static ?string $navigationIcon = 'heroicon-o-rectangle-stack';

    protected static ?string $navigationLabel = 'Advertisements';

    protected static ?string $navigationGroup = 'Content Management';

    protected static ?int $navigationSort = 3;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Section::make('Basic Information')
                    ->schema([
                        TextInput::make('title')
                            ->required()
                            ->maxLength(255)
                            ->placeholder('e.g., GrabFood Discount Campaign'),

                        Textarea::make('description')
                            ->rows(3)
                            ->maxLength(500)
                            ->placeholder('Brief description of the advertisement'),

                        Select::make('type')
                            ->label('Advertisement Type')
                            ->options([
                                'video' => 'Video',
                                'image' => 'Image',
                            ])
                            ->required()
                            ->live()
                            ->afterStateUpdated(fn ($state, callable $set) =>
                                $state === 'image' ? $set('duration', 15) : $set('duration', null)
                            ),
                    ])
                    ->columns(1),

                Section::make('Media Upload')
                    ->schema([
                        FileUpload::make('file_path')
                            ->label('Video File')
                            ->directory('advertisements')
                            ->acceptedFileTypes(['video/mp4', 'video/webm', 'video/mov'])
                            ->maxSize(1024000) // 100MB
                            ->required()
                            ->columnSpanFull()
                            ->visible(fn ($get) => $get('type') === 'video'),

                        FileUpload::make('file_path')
                            ->label('Image File')
                            ->directory('advertisements')
                            ->acceptedFileTypes(['image/jpeg', 'image/png', 'image/jpg', 'image/webp'])
                            ->maxSize(102400) // 10MB
                            ->required()
                            ->columnSpanFull()
                            ->visible(fn ($get) => $get('type') === 'image'),

                        FileUpload::make('thumbnail')
                            ->label('Thumbnail (Optional)')
                            ->directory('advertisements/thumbnails')
                            ->image()
                            ->maxSize(5120)
                            ->helperText('Recommended for videos. Will be auto-generated if not provided.')
                            ->columnSpanFull()
                            ->visible(fn ($get) => $get('type') === 'video'),
                    ]),

                Section::make('Display Settings')
                    ->schema([
                        TextInput::make('duration')
                            ->label('Duration (seconds)')
                            ->numeric()
                            ->default(15)
                            ->required()
                            ->helperText('How long the ad will be displayed (for images)')
                            ->visible(fn ($get) => $get('type') === 'image'),

                        TextInput::make('priority')
                            ->label('Priority')
                            ->numeric()
                            ->default(0)
                            ->required()
                            ->helperText('Higher priority ads will be shown first (0 = normal)'),

                        Toggle::make('is_active')
                            ->label('Active')
                            ->default(true)
                            ->helperText('Only active ads will be shown in the app'),
                    ])
                    ->columns(3),

                Section::make('Demographic Targeting')
                    ->description('Select target demographics for this advertisement')
                    ->schema([
                        Select::make('target_gender')
                            ->label('Target Gender')
                            ->options([
                                'all' => 'All',
                                'male' => 'Male',
                                'female' => 'Female',
                            ])
                            ->multiple()
                            ->default(['all'])
                            ->required()
                            ->helperText('Which gender should see this ad?')
                            ->preload(),

                        Select::make('target_age_group')
                            ->label('Target Age Group')
                            ->options([
                                'all' => 'All Ages',
                                'child' => 'Child (0-12)',
                                'teen' => 'Teen (13-19)',
                                'adult' => 'Adult (20-59)',
                                'senior' => 'Senior (60+)',
                            ])
                            ->multiple()
                            ->default(['all'])
                            ->required()
                            ->helperText('Which age group should see this ad?')
                            ->preload(),
                    ])
                    ->columns(2)
                    ->collapsible(),

                Section::make('Schedule (Optional)')
                    ->schema([
                        Forms\Components\DateTimePicker::make('start_date')
                            ->label('Start Date')
                            ->helperText('When this ad should start showing'),

                        Forms\Components\DateTimePicker::make('end_date')
                            ->label('End Date')
                            ->helperText('When this ad should stop showing')
                            ->after('start_date'),
                    ])
                    ->columns(2)
                    ->collapsible()
                    ->collapsed(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ViewColumn::make('preview')
                    ->view('filament.tables.columns.ad-preview'),

                TextColumn::make('title')
                    ->searchable()
                    ->sortable()
                    ->limit(30)
                    ->weight('bold'),

                TextColumn::make('type')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'video' => 'info',
                        'image' => 'success',
                        default => 'gray',
                    })
                    ->icon(fn (string $state): string => match ($state) {
                        'video' => 'heroicon-o-film',
                        'image' => 'heroicon-o-photo',
                        default => 'heroicon-o-question-mark-circle',
                    }),

                TextColumn::make('target_gender')
                    ->label('Gender Target')
                    ->badge()
                    ->formatStateUsing(fn ($state) => is_array($state) ? implode(', ', $state) : $state)
                    ->color('warning'),

                TextColumn::make('target_age_group')
                    ->label('Age Target')
                    ->badge()
                    ->formatStateUsing(fn ($state) => is_array($state) ? implode(', ', $state) : $state)
                    ->color('success'),

                TextColumn::make('priority')
                    ->sortable()
                    ->alignCenter()
                    ->badge()
                    ->color(fn (int $state): string => match (true) {
                        $state > 5 => 'danger',
                        $state > 0 => 'warning',
                        default => 'gray',
                    }),

                TextColumn::make('duration')
                    ->label('Duration')
                    ->formatStateUsing(fn ($state, $record) =>
                        $record->type === 'image' ? $state . 's' : 'Auto'
                    )
                    ->alignCenter(),

                ToggleColumn::make('is_active')
                    ->label('Active')
                    ->sortable(),

                TextColumn::make('created_at')
                    ->label('Created')
                    ->dateTime('d M Y')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('priority', 'desc')
            ->filters([
                SelectFilter::make('type')
                    ->options([
                        'video' => 'Video',
                        'image' => 'Image',
                    ]),

                TernaryFilter::make('is_active')
                    ->label('Active Status')
                    ->placeholder('All')
                    ->trueLabel('Active Only')
                    ->falseLabel('Inactive Only'),

                SelectFilter::make('target_gender')
                    ->label('Gender Target')
                    ->options([
                        'all' => 'All',
                        'male' => 'Male',
                        'female' => 'Female',
                    ])
                    ->query(function ($query, $state) {
                        if ($state['value']) {
                            return $query->whereJsonContains('target_gender', $state['value']);
                        }
                    }),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                    Tables\Actions\BulkAction::make('activate')
                        ->label('Activate Selected')
                        ->icon('heroicon-o-check-circle')
                        ->color('success')
                        ->action(fn ($records) => $records->each->update(['is_active' => true]))
                        ->deselectRecordsAfterCompletion(),
                    Tables\Actions\BulkAction::make('deactivate')
                        ->label('Deactivate Selected')
                        ->icon('heroicon-o-x-circle')
                        ->color('danger')
                        ->action(fn ($records) => $records->each->update(['is_active' => false]))
                        ->deselectRecordsAfterCompletion(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListAdvertisements::route('/'),
            'create' => Pages\CreateAdvertisement::route('/create'),
            'edit' => Pages\EditAdvertisement::route('/{record}/edit'),
            // 'view' => Pages\ViewAdvertisement::route('/{record}'),
        ];
    }
}
