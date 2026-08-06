<?php

namespace App\Filament\Resources;

use App\Filament\Resources\RunningTextResource\Pages;
use App\Models\RunningText;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class RunningTextResource extends Resource
{
    protected static ?string $model = RunningText::class;

    protected static ?string $navigationIcon = 'heroicon-o-megaphone';

    protected static ?string $navigationLabel = 'Running Texts';

    protected static ?string $navigationGroup = 'Content Management';

    protected static ?int $navigationSort = 2;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Running Text Content')
                    ->schema([
                        Forms\Components\Textarea::make('text')
                            ->required()
                            ->rows(3)
                            ->maxLength(500)
                            ->columnSpanFull()
                            ->helperText('Text yang akan ditampilkan sebagai running text'),

                        Forms\Components\Select::make('position')
                            ->options([
                                'top' => 'Top (Atas)',
                                'bottom' => 'Bottom (Bawah)',
                            ])
                            ->required()
                            ->default('bottom')
                            ->helperText('Posisi running text di layar'),

                        Forms\Components\Toggle::make('is_active')
                            ->label('Active')
                            ->default(true)
                            ->helperText('Aktifkan atau nonaktifkan running text ini'),
                    ])
                    ->columns(2),

                Forms\Components\Section::make('Priority & Display')
                    ->schema([
                        Forms\Components\TextInput::make('priority')
                            ->numeric()
                            ->default(0)
                            ->helperText('Priority lebih tinggi = ditampilkan lebih dulu (saat ada bentrok)'),

                        Forms\Components\TextInput::make('display_duration')
                            ->label('Display Duration (seconds)')
                            ->numeric()
                            ->default(30)
                            ->minValue(5)
                            ->maxValue(300)
                            ->suffix('seconds')
                            ->helperText('Berapa lama running text ini ditampilkan sebelum ganti (rotation)'),
                    ])
                    ->columns(2),

                Forms\Components\Section::make('Styling')
                    ->schema([
                        Forms\Components\ColorPicker::make('background_color')
                            ->label('Background Color')
                            ->helperText('Warna background running text (hex atau rgba)')
                            ->default('#000000'),

                        Forms\Components\ColorPicker::make('text_color')
                            ->label('Text Color')
                            ->helperText('Warna text running text')
                            ->default('#FFFFFF'),

                        Forms\Components\TextInput::make('font_size')
                            ->label('Font Size')
                            ->numeric()
                            ->default(16)
                            ->minValue(10)
                            ->maxValue(100)
                            ->suffix('px')
                            ->helperText('Ukuran font (10-100 px)'),

                        Forms\Components\TextInput::make('speed')
                            ->label('Scroll Speed')
                            ->numeric()
                            ->default(50)
                            ->minValue(10)
                            ->maxValue(200)
                            ->suffix('px/s')
                            ->helperText('Kecepatan scroll (pixels per second)'),
                    ])
                    ->columns(2),

                Forms\Components\Section::make('Scheduling - Date Range')
                    ->description('Tentukan periode kapan running text ini aktif')
                    ->schema([
                        Forms\Components\DatePicker::make('start_date')
                            ->label('Start Date')
                            ->helperText('Mulai tanggal (kosongkan jika mulai sekarang)'),

                        Forms\Components\DatePicker::make('end_date')
                            ->label('End Date')
                            ->helperText('Sampai tanggal (kosongkan jika tidak ada batas)')
                            ->afterOrEqual('start_date'),
                    ])
                    ->columns(2)
                    ->collapsible(),

                Forms\Components\Section::make('Scheduling - Daily Time Slot')
                    ->description('Tentukan jam berapa saja running text ini tampil (setiap hari)')
                    ->schema([
                        Forms\Components\TimePicker::make('start_time')
                            ->label('Start Time')
                            ->seconds(false)
                            ->helperText('Jam mulai (kosongkan jika aktif sepanjang hari)'),

                        Forms\Components\TimePicker::make('end_time')
                            ->label('End Time')
                            ->seconds(false)
                            ->helperText('Jam selesai (kosongkan jika aktif sepanjang hari)'),
                    ])
                    ->columns(2)
                    ->collapsible(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('id')
                    ->label('ID')
                    ->sortable()
                    ->searchable(),

                Tables\Columns\TextColumn::make('text')
                    ->label('Running Text')
                    ->limit(50)
                    ->searchable()
                    ->tooltip(function (Tables\Columns\TextColumn $column): ?string {
                        $state = $column->getState();
                        if (strlen($state) > 50) {
                            return $state;
                        }
                        return null;
                    }),

                Tables\Columns\BadgeColumn::make('position')
                    ->label('Position')
                    ->colors([
                        'primary' => 'top',
                        'success' => 'bottom',
                    ])
                    ->formatStateUsing(fn (string $state): string => strtoupper($state)),

                Tables\Columns\TextColumn::make('priority')
                    ->sortable()
                    ->badge()
                    ->color(fn (int $state): string => match (true) {
                        $state >= 10 => 'danger',
                        $state >= 5 => 'warning',
                        default => 'gray',
                    }),

                Tables\Columns\IconColumn::make('is_active')
                    ->label('Active')
                    ->boolean()
                    ->sortable(),

                Tables\Columns\TextColumn::make('display_duration')
                    ->label('Duration')
                    ->suffix('s')
                    ->sortable(),

                Tables\Columns\TextColumn::make('start_date')
                    ->label('Start Date')
                    ->date()
                    ->sortable()
                    ->toggleable(),

                Tables\Columns\TextColumn::make('end_date')
                    ->label('End Date')
                    ->date()
                    ->sortable()
                    ->toggleable(),

                Tables\Columns\TextColumn::make('start_time')
                    ->label('Start Time')
                    ->time('H:i')
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('end_time')
                    ->label('End Time')
                    ->time('H:i')
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Created')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('updated_at')
                    ->label('Updated')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('priority', 'desc')
            ->filters([
                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('Active Status')
                    ->placeholder('All')
                    ->trueLabel('Active Only')
                    ->falseLabel('Inactive Only'),

                Tables\Filters\SelectFilter::make('position')
                    ->options([
                        'top' => 'Top',
                        'bottom' => 'Bottom',
                    ]),

                Tables\Filters\Filter::make('currently_active')
                    ->label('Currently Active')
                    ->query(fn (Builder $query): Builder => $query->currentlyActive())
                    ->toggle(),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),

                // Custom action untuk toggle active
                Tables\Actions\Action::make('toggle_active')
                    ->label(fn (RunningText $record) => $record->is_active ? 'Deactivate' : 'Activate')
                    ->icon(fn (RunningText $record) => $record->is_active ? 'heroicon-o-x-circle' : 'heroicon-o-check-circle')
                    ->color(fn (RunningText $record) => $record->is_active ? 'danger' : 'success')
                    ->action(function (RunningText $record) {
                        $record->update(['is_active' => !$record->is_active]);
                    })
                    ->requiresConfirmation(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),

                    // Bulk activate
                    Tables\Actions\BulkAction::make('activate')
                        ->label('Activate Selected')
                        ->icon('heroicon-o-check-circle')
                        ->color('success')
                        ->action(function ($records) {
                            $records->each->update(['is_active' => true]);
                        })
                        ->deselectRecordsAfterCompletion(),

                    // Bulk deactivate
                    Tables\Actions\BulkAction::make('deactivate')
                        ->label('Deactivate Selected')
                        ->icon('heroicon-o-x-circle')
                        ->color('danger')
                        ->action(function ($records) {
                            $records->each->update(['is_active' => false]);
                        })
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
            'index' => Pages\ListRunningTexts::route('/'),
            'create' => Pages\CreateRunningText::route('/create'),
            'edit' => Pages\EditRunningText::route('/{record}/edit'),
        ];
    }

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::currentlyActive()->count();
    }

    public static function getNavigationBadgeColor(): ?string
    {
        $count = static::getModel()::currentlyActive()->count();
        return $count > 0 ? 'success' : 'gray';
    }
}
